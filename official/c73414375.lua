--ディメンション・ポッド
--Dimension Jar
local s,id=GetID()
function s.initial_effect(c)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,3,PLAYER_ALL,LOCATION_GRAVE)
end
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp) and aux.SpElimFilter(c)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local p=Duel.GetTurnPlayer()
	if Duel.IsExistingTarget(s.rmfilter,p,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,1-p) and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(p,s.rmfilter,p,0,LOCATION_MZONE|LOCATION_GRAVE,1,3,nil,p)
		Duel.HintSelection(rg,true)
		g:Merge(rg)
	end
	if Duel.IsExistingTarget(s.rmfilter,1-p,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,1-p) and Duel.SelectYesNo(1-p,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(1-p,s.rmfilter,1-p,0,LOCATION_MZONE|LOCATION_GRAVE,1,3,nil,1-p)
		Duel.HintSelection(rg,true)
		g:Merge(rg)
	end
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end