--グラビティアラ・アイ
--Gravitiara Ai
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 3 cards and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	Duel.DisableShuffleCheck()
	local sg=g:Filter(s.filter,nil)
	if #sg>0 then
		Duel.MoveToDeckTop(sg,tp)
		Duel.SortDecktop(tp,tp,#sg)
		g:RemoveCard(sg)
	end
	if #g>0 then
		Duel.MoveToDeckBottom(g,tp)
		Duel.SortDeckbottom(tp,tp,#g)
	end
	if #sg>=4 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
