import groovy.swing.SwingBuilder
import java.awt.FlowLayout as FL
import javax.swing.DefaultComboBoxModel
import javax.swing.BoxLayout as BXL
import groovy.beans.Bindable;

import oracle.odi.core.persistence.transaction.support.DefaultTransactionDefinition;
import oracle.odi.domain.util.ObfuscatedString;
import oracle.odi.domain.model.OdiModel;
import oracle.odi.domain.model.finder.IOdiModelFinder;
import oracle.odi.domain.model.OdiDataStore;
import oracle.odi.domain.model.OdiColumn;
import oracle.odi.domain.project.OdiVariable.DataType;

class Model
{
	@Bindable DefaultComboBoxModel  toItems
        @Bindable ObservableList comboBoxValues = ['WORK_STATION_AD'] as ObservableList
}

def captureInput() 
{

  txnDef = new DefaultTransactionDefinition();
  tm = odiInstance.getTransactionManager()
  txnStatus = tm.getTransaction(txnDef)

  models = []

  modelFinder = (IOdiModelFinder) odiInstance.getTransactionalEntityManager().getFinder(OdiModel.class);
  modelM = modelFinder.findAll();
  conItr = modelM.iterator()

  while (conItr.hasNext()) 
  {
    mod = (OdiModel) conItr.next()
    models.add(mod.getCode())
  }

  tm.commit(txnStatus)

  Model m=new Model()
  d = new java.awt.Dimension(205,20)
  m.toItems = new DefaultComboBoxModel(models as Object[])

  def s = new SwingBuilder()
  s.setVariable('myDialog-properties',[:])

  def vars = s.variables
  def dial = s.dialog(title:'Add Columns to ODI Model', id:'myDialog', modal:true) 
  {
    panel() 
	{
        boxLayout(axis:BXL.Y_AXIS)

        panel(alignmentX:0f) {
            flowLayout(alignment:FL.RIGHT)
            label('Model Code:')
            comboBox(id:'modelCode', items: m.comboBoxValues, null, preferredSize:d)
    }
    panel(alignmentX:0f) 
	{
            flowLayout(alignment:FL.LEFT)
            button('OK',preferredSize:[80,24],
                   actionPerformed:
				   {
                       vars.dialogResult = 'OK'
                       dispose()
				   })
            button('Cancel',preferredSize:[80,24],
                   actionPerformed:
				   {
                       vars.dialogResult = 'cancel'
                       dispose()
                   })
    }
  } 
}
  dial.pack()
  dial.show()

  return vars
}

def addColumns(modCode) 
{
  txnDef = new DefaultTransactionDefinition();
  tm = odiInstance.getTransactionManager()
  txnStatus = tm.getTransaction(txnDef)

  modFinder = (IOdiModelFinder) odiInstance.getTransactionalEntityManager().getFinder(OdiModel.class);
  mod = modFinder.findByCode(modCode);

  Collection<OdiDataStore> dataStores = mod.getGlobalSubModel().getDataStores();
  dsArray = dataStores.toArray(new OdiDataStore[0]);
  
  def my_numbers = [8, 
8, 
6, 
2, 
7, 
4, 
17, 
8, 
5, 
2, 
4, 
4, 
7, 
4, 
3, 
40, 
4, 
2, 
10, 
10, 
10, 
10, 
2, 
10, 
10, 
10, 
18, 
18, 
18, 
18
];
  
  def dwh_columns = ['EXTRACT_NAME', 
'EXTRACT_DATE', 
'EXTRACT_TIME', 
'RECORD_TYPE', 
'FILE_NAME', 
'BANK_NBR', 
'CLIENT_NBR', 
'PRODUCT_ID', 
'SEQ_NBR', 
'TABLE_ENTRY_NBR', 
'ACCT_TYPE', 
'BRANCH', 
'USER_COUNT_5', 
'ACCT_GL_TBL', 
'LINE_NBR', 
'COBOL_FIELD_NAME', 
'GROUP_CODE', 
'ROUNDING_OPTION', 
'ROUNDING_METHOD', 
'NEW_CURR_ISO_CODE', 
'OLD_CURR_ISO_CODE', 
'NEW_CURR_NBR', 
'OLD_CURR_NBR', 
'OLD_CURR_NBR_DEC_PLACES', 
'NEW_CURR_NBR_DEC_PLACES', 
'OLD_VALUE', 
'NEW_VALUE', 
'NEW_VALUE_MATH', 
'ROUNDING_DIFF', 
'SUMMARY_DIFF'
];

    OdiDataStore ds = null;
    ds = dsArray[0];

    for (int j = 0; j < 2; j++)
    {
        col = new OdiColumn(ds, dwh_columns[j]);
        col.setDataTypeCode("STRING");
        col.setLength(my_numbers[j]);
        col.setMandatory(false);
    }

    odiInstance.getTransactionalEntityManager().persist(ds)

  tm.commit(txnStatus)
  return mod
}

vars= captureInput()

if (vars.dialogResult == 'OK')
{
  addColumns(vars.modelCode.selectedItem)
}
