--名匠 虎鉄
--Master Craftsman Kotetsu
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--recycle and draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e)return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160206045}
function s.tdfilter(c)
	return c:IsAbleToDeck() and (c:IsEquipSpell() or (c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tg,true)
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local tc=tg:GetFirst()
	if ((tc:IsMonster() and tc:IsLegend()) or tc:IsCode(160206045)) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
