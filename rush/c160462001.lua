--塗り足のパレッタ
--Paletta the Foot Painter
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 3 cards and send 1 to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.typefilter(c,sc)
	return c:IsFaceup() and c:IsNotMaximumModeSide() and (c:CanChangeIntoTypeRush(sc:GetType(),2) or c:CanChangeIntoAttributeRush(sc:GetAttribute(),2))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local g=Duel.GetDeckbottomGroup(tp,3)
	Duel.ConfirmCards(tp,g)
	Duel.ConfirmCards(1-tp,g)
	if g:IsExists(Card.IsMonster,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:FilterSelect(tp,Card.IsMonster,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.BreakEffect()
		local sc=sg:GetFirst()
		if Duel.IsExistingMatchingCard(s.typefilter,tp,0,LOCATION_MZONE,1,nil,sc) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
			local dg=Duel.SelectMatchingCard(tp,s.typefilter,tp,0,LOCATION_MZONE,1,1,nil,sc)
			Duel.HintSelection(dg)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(sc:GetRace())
			e1:SetReset(RESETS_STANDARD_PHASE_END,2)
			dg:GetFirst():RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetValue(sc:GetAttribute())
			e2:SetReset(RESETS_STANDARD_PHASE_END,2)
			dg:GetFirst():RegisterEffect(e2)
		end
	end
	Duel.ShuffleDeck(tp)
end