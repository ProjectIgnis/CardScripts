--サイバースパイス・ターメリック
--Cybersepice Turmeric
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Reveal
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
function s.filter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_STZONE,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,e:GetHandler(),1,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_STZONE,1,1,nil):GetFirst()
	if not tc then return end
	Duel.ConfirmCards(tp,tc)
	if tc:IsTrap() then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end