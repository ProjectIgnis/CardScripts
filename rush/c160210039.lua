--超銀河王ロード・オブ・ギャラクティカ［Ｒ］
--Super Galaxy King Lord of Galactica [R]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.maxCon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Right"
function s.maxCon(e)
	return e:GetHandler():IsMaximumModeCenter()
end
function s.filter(c,g)
	if not c:IsFaceup() or c:IsMaximumModeSide() then return false end
	return g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99)
end
function s.filter2(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,g) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_HAND,0,nil)
	--Choose a monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,g):GetFirst()
	Duel.HintSelection(tc,true)
	local tg=g:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,99)
	if Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tc:GetAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local c=e:GetHandler()
		--Gain ATK
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(tc:GetAttack())
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e2)
	end
end