--ヘル・テンペスト (Anime)
--Inferno Tempest (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetBattleDamage(tp)>=3000
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and (c:IsLocation(LOCATION_DECK) or aux.SpElimFilter(c))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_DECK+LOCATION_GRAVE,nil)
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
		local g=sg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		g:KeepAlive()
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(EFFECT_FORBIDDEN)
		e2:SetTargetRange(0x7f,0x7f)
		e2:SetTarget(s.bantg)
		e2:SetLabelObject(g)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(0x7f,0x7f)
		e3:SetTarget(s.bantg)
		e3:SetLabelObject(g)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.bantg(e,c)
	return (not c:IsOnField() or c:GetRealFieldID()>e:GetFieldID()) and e:GetLabelObject():IsContains(c)
end