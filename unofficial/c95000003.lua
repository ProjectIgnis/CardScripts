--ダークネス／魔法Ａ
--Darkness/Spell A (Darkness)
local s,id=GetID()
function s.initial_effect(c)
	--Activate (Set Darkness/Trap A, B, C, D, and E from your hand or Deck)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Once per turn, this card cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetValue(function(e,re,r,rp) return (r&REASON_EFFECT)>0 end)
	c:RegisterEffect(e2)
	--Activation and effects of Continuous Traps you control cannot be negated
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetValue(s.effectfilter)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetValue(s.effectfilter)	
	c:RegisterEffect(e4)
	--(Hidden Effect) Return all other Spell/Trap cards on the field to the hand
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_names={95000004,95000005,95000006,95000007,95000008} --"Darkness/Trap A", "Darkness/Trap B", "Darkness/Trap C", "Darkness/Trap D", "Darkness/Trap E",
s.mark=0
function s.setfilter(c)
	return c:IsCode(95000004,95000005,95000006,95000007,95000008) and c:IsSSetable(true)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil):GetClassCount(Card.GetCode)==5 end
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,95000004) and sg:IsExists(Card.IsCode,1,nil,95000005) and sg:IsExists(Card.IsCode,1,nil,95000006) 
		and sg:IsExists(Card.IsCode,1,nil,95000007) and sg:IsExists(Card.IsCode,1,nil,95000008)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<5 then return end
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	if not s.rescon(sg) then return end
	local setg=aux.SelectUnselectGroup(sg,e,tp,5,5,s.rescon,1,tp,HINTMSG_SET)
	if #sg>0 then
		Duel.SSet(tp,setg)
	end
end
function s.effectfilter(e,ct)
	local trig_e=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)	
	local trig_c=trig_e:GetHandler()
	if not (trig_e:IsTrapEffect() and trig_c:IsContinuousTrap()) then return false end
	return trig_c:IsControler(e:GetHandlerPlayer()) and trig_c:IsLocation(LOCATION_ONFIELD) and trig_c:IsFaceup()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end 
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
