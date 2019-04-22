--Cybernetic Innovative Technology
--Quick-play spell
--Reveal 1 "Cyber Dragon in hand" Special summon 1 “Cyber Laser Dragon” OR “Cyber Barrier Dragon” from your hand, Deck, or GY, ignoring its summoning conditions. You can banish this card from your GY and target 1 level 5 or higher LIGHT Machine “Cyber” monster on your side of the field; it cannot be destroyed by battle or card effects this turn, also you can switch its battle position.
function c210555557.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(210555557,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCost(c210555557.cost)
  e1:SetTarget(c210555557.target)
  e1:SetOperation(c210555557.activate)
  c:RegisterEffect(e1)
  --change target
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(210555557,1))
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetCategory(CATEGORY_POSITION)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(c210555557.prottarget)
  e2:SetOperation(c210555557.protop)
  c:RegisterEffect(e2)
end
function c210555557.spcfilter(c,e,tp)
  return c:IsSetCard(0x1093)
end
function c210555557.cost(e,tp,eg,ep,ev,re,r,rp,chk)

 if chk==0 then return Duel.IsExistingMatchingCard(c210555557.spcfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
  local g=Duel.SelectMatchingCard(tp,c210555557.spcfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
  Duel.ConfirmCards(1-tp,g)
  Duel.ShuffleHand(tp)
end
function c210555557.spfilter(c,e,tp)
  return c:IsCode(68774379,04162088)  and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c210555557.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsExistingMatchingCard(c210555557.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function c210555557.activate(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,c210555557.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
  if g:GetCount()>0 then
    Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
  end
end
function c210555557.protfilter(c)
  return (c:IsSetCard(0x103) or c:IsSetCard(0x93) or c:IsSetCard(0x1093)) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetLevel()>4
end
function c210555557.prottarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and c210555557.protfilter(chkc) end
  if chk==0 then return Duel.IsExistingTarget(c210555557.protfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
  Duel.SelectTarget(tp,c210555557.protfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c210555557.protop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
    end
  if tc and tc:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(210555557,2)) then
      Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
  end 
end
  