--アルマストラⅩⅠ－アクエリアス
--Almastra XI - Aquarius
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 3 cards and send 1 to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	if #g>0 then
		if g:GetSum(Card.GetLevel)>=11 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
			g2=g2:AddMaximumCheck()
			Duel.HintSelection(g2,true)
			Duel.Destroy(g2,REASON_EFFECT)
		end
		Duel.ShuffleDeck(tp)
	end
end