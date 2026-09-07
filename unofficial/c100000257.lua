--カオス・コア (Anime)
--Chaos Core (Anime)
local s,id=GetID()
local COUNTER_PHANTASM=0x202
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_PHANTASM)
	--If this Attack Position card is selected as an attack target by an opponent's monster, you can send 1 "Uria, Lord of Searing Flames", "Hamon, Lord of Striking Thunder", and "Raviel, Lord of Phantasms" from your hand or Deck to the Graveyard and place 3 Phantasm Counters on this card. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3657444,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(function(e,tp) return e:GetHandler():IsAttackPos() and Duel.GetAttacker() and Duel.GetAttacker():IsControler(1-tp) end)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--If this card is attacked, during the Damage Step: You can remove 1 Phantasm Counter from this card; this card cannot be destroyed by that battle, also you take no battle damage from that battle.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3657444,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.batindescon)
	e2:SetCost(Cost.RemoveCounterFromSelf(COUNTER_PHANTASM,1))
	e2:SetOperation(s.batindesop)
	c:RegisterEffect(e2)
end
s.counter_place_list=COUNTER_PHANTASM
s.listed_names={69890967,6007213,32491822} --"Uria, Lord of Searing Flames", "Hamon, Lord of Striking Thunder", "Raviel, Lord of Phantasms"
function s.ctfilter(c)
	return c:IsCode(69890967,6007213,32491822) and c:IsAbleToGrave()
end
function s.ctcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetCode)==3 and e:GetHandler():IsCanAddCounter(COUNTER_PHANTASM,3)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.ctcheck,0) and e:GetHandler():IsCanAddCounter(COUNTER_PHANTASM,3) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,0,COUNTER_PHANTASM)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.ctcheck,1,tp,HINTMSG_TOGRAVE)
	if #sg==3 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==3 
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(COUNTER_PHANTASM,3)
	end
end
function s.batindescon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at and at==e:GetHandler()
end
function s.batindesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		c:RegisterEffect(e2)
	end
end
