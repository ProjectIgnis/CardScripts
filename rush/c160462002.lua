--枯れ木のジニー
--Genie of the Dead Tree
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Equip this card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.equipfilter(c)
	return c:IsFaceup() and c:GetEquipGroup():FilterCount(Card.IsCode,nil,id)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.equipfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.equipfilter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	Duel.Equip(tp,c,tc,true)
	s.eqeffect(c,tc)
	Duel.Recover(tp,500,REASON_EFFECT)
end
function s.eqeffect(c,tc)
	--Add Equip limit
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)
	--ATK decrease
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetValue(tc:GetOriginalLevel()*-100)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.atktg(e,c)
	local tp=e:GetHandlerPlayer()
	local ec=e:GetHandler():GetEquipTarget()
	return c:IsFaceup() and (c:IsControler(1-tp) or c==ec)
end