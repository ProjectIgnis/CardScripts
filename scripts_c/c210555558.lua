--Cyber Dragon Funf:
--You can Fusion Summon 1 LIGHT Monster from your Extra Deck, using monsters from your hand or field as Fusion Materials including this card. If Summoning a “Cyber” Fusion Monster this way, you can also banish monsters from your GY as Fusion Material. If this card is banished: You can target 1 Spell/Trap card on the field; destroy it. You can only use each effect of “Cyber Dragon Funf” once per turn. This card’s name becomes “Cyber Dragon” while it is on the field, in the GY, or in your hand.
function c210555558.initial_effect(c)

  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(210555558,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1,210555558)
  e1:SetTarget(c210555558.target)
  e1:SetOperation(c210555558.operation)
  c:RegisterEffect(e1) 
  --banished:pop
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(210555558,1))
  e2:SetCategory(CATEGORY_DESTROY)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_REMOVE)
  e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e2:SetCountLimit(1,210555558+100)
  e2:SetTarget(c210555558.desttg)
  e2:SetOperation(c210555558.destop)
  c:RegisterEffect(e2)
  --Is it a cyberdragon or not?
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e3:SetCode(EFFECT_CHANGE_CODE)
  e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
  e3:SetValue(70095154)
  c:RegisterEffect(e3)
 
end
function c210555558.mfilter0(c)
  return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function c210555558.mfilter1(c,e)
  return not c:IsImmuneToEffect(e)
end
function c210555558.mfilter2(c,e)
  return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c210555558.spfilter1(c,e,tp,m,f,gc,chkf)
  return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_LIGHT) and (not f or f(c))
    and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c210555558.spfilter2(c,e,tp,m,f,gc,chkf)
  return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_LIGHT) and (c:IsSetCard(0x103) or c:IsSetCard(0x93)) and (not f or f(c))
    and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c210555558.target(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then
    local mg1=Duel.GetFusionMaterial(tp)
      local chkf=tp
    local res=Duel.IsExistingMatchingCard(c210555558.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
    if res then return true end
    local mg2=Group.CreateGroup()
    if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
      mg2:Merge(Duel.GetMatchingGroup(c210555558.mfilter0,tp,LOCATION_GRAVE,0,nil))
    end
    mg2:Merge(mg1)
    res=Duel.IsExistingMatchingCard(c210555558.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,c,chkf)
    if not res then
      local ce=Duel.GetChainMaterial(tp)
      if ce~=nil then
        local fgroup=ce:GetTarget()
        local mg3=fgroup(ce,e,tp)
        local mf=ce:GetValue()
        res=Duel.IsExistingMatchingCard(c210555558.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf)
      end
    end
    return res
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c210555558.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local chkf=tp
  if not c:IsRelateToEffect(e) then return end
  local mg1=Duel.GetFusionMaterial(tp):Filter(c210555558.mfilter1,nil,e)
  local sg1=Duel.GetMatchingGroup(c210555558.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil)
  local mg2=Group.CreateGroup()
  if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
    mg2:Merge(Duel.GetMatchingGroup(c210555558.mfilter2,tp,LOCATION_GRAVE,0,nil,e,tp,mg1,nil,c,chkf))
  end
  mg2:Merge(mg1)
  local sg2=Duel.GetMatchingGroup(c210555558.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,nil)
  sg1:Merge(sg2)
  local mg3=nil
  local sg3=nil
  local ce=Duel.GetChainMaterial(tp)
  if ce~=nil then
    local fgroup=ce:GetTarget()
    mg3=fgroup(ce,e,tp)
    local mf=ce:GetValue()
    sg3=Duel.GetMatchingGroup(c210555558.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
  end
  if sg1:GetCount()>0 or (sg3~=nil and sg3:GetCount()>0) then
    local sg=sg1:Clone()
    if sg3 then sg:Merge(sg3) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=sg:Select(tp,1,1,nil)
    local tc=tg:GetFirst()
    if sg1:IsContains(tc) and (sg3==nil or not sg3:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
      if tc:IsSetCard(0x93) or c:IsSetCard(0x103) then
        local mat1=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
        tc:SetMaterial(mat1)
        local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
        mat1:Sub(mat2)
        Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
      else
        local mat2=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
        tc:SetMaterial(mat2)
        Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
      end
      Duel.BreakEffect()
      Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    else
      local mat=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
      local fop=ce:GetOperation()
      fop(ce,e,tp,tc,mat)
    end
    tc:CompleteProcedure()
  end
end
function c210555558.filter(c)
  return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c210555558.desttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsOnField() and c210555558.filter(chkc) and chkc~=e:GetHandler() end
  if chk==0 then return Duel.IsExistingTarget(c210555558.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,c210555558.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c210555558.destop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) then
    Duel.Destroy(tc,REASON_EFFECT)
  end
end