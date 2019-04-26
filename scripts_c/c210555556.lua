--Cyber Hive Mind
--Continuous spell
--When this card is activated: Send 1 “Cyber Dragon” monster from your deck to your GY. Once while face-up on the field: you can Normal Summon a “Cyber Dragon” monster in addition to your Normal Summon or Set. (You can only gain this effect once per turn.) If this face-up card in the Spell & Trap Zone is destroyed by a card effect: You can take 1 “Cyber” Spell/Trap from your Deck or GY except “Cyber Hive Mind”, and either add it to your hand or set it to your side of the field. You can only use each effect of “Cyber Hive Mind” once per turn.
 
function c210555556.initial_effect(c)
  --Send Cydra To Grave
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(210555556,0))
  e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,210555556)
  e1:SetTarget(c210555556.target)
  e1:SetOperation(c210555556.activate)
  c:RegisterEffect(e1)
  --Double Summon
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
  e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
  e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1093))
  c:RegisterEffect(e2)    
  --Search 
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e3:SetDescription(aux.Stringid(210555556,1))
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_DESTROYED)
  e3:SetCountLimit(1,210555556+100)
  e3:SetTarget(c210555556.destg)
  e3:SetOperation(c210555556.destop)
  e3:SetCondition(c210555556.descon)  
  c:RegisterEffect(e3)
end
function c210555556.filter(c,tp)
  return c:IsSetCard(0x1093) and c:IsType(TYPE_MONSTER)  and c:IsAbleToGrave()
end
function c210555556.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(c210555556.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end  
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c210555556.activate(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetMatchingGroup(c210555556.filter,tp,LOCATION_DECK,0,nil)
  if g:GetCount()>0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOGRAVE)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoGrave(sg,nil,REASON_EFFECT)
  end
end
function c210555556.destfilter(c)
  return c:IsSetCard(0x93) and not c:IsCode(210555556) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c210555556.descon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPreviousPosition(POS_FACEUP) and bit.band(r,REASON_EFFECT)~=0
end

function c210555556.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c210555556.destop(e,tp,eg,ep,ev,re,r,rp)
  
  local tc=Duel.SelectMatchingCard(tp,c210555556.destfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
  if tc:GetCount()>0 then
   if Duel.SelectYesNo(tp,aux.Stringid(210555556,2)) then
       Duel.SSet(tp,tc)
      Duel.ConfirmCards(1-tp,tc)
    else
      Duel.SendtoHand(tc,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,tc)
     
    end
  end
end