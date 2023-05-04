--アルテネの加護
--Protection of Arthenée
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit,s.cost,nil,s.operation)
	--Cannot be destroyed by the opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.condition)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(Card.IsEquipSpell,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end