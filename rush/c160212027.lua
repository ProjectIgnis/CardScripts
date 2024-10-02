--イービル・ボーラー
--Evil Baller
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change 1 monster's Type
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.revfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDefense(500) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.rcfilter,tp,0,LOCATION_MZONE,1,nil,c)
end
function s.rcfilter(c,rvlc)
	return c:IsFaceup() and (not c:IsRace(RACE_FIEND) or not c:IsRace(rvlc:GetRace())) and c:IsNotMaximumModeSide()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rvlc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	local oldRace=rvlc:GetRace()
	Duel.ConfirmCards(1-tp,rvlc)
	Duel.ShuffleHand(tp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.rcfilter,tp,0,LOCATION_MZONE,1,1,nil,rvlc):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc)
	local newRace=nil
	if tc:IsRace(RACE_FIEND) then
		newRace=rvlc:GetRace()
	elseif tc:IsRace(rvlc:GetRace()) or rvlc:IsRace(RACE_FIEND) then
		newRace=RACE_FIEND
	else
		local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		if opt==0 then
			newRace=RACE_FIEND
		elseif opt==1 then
			newRace=rvlc:GetRace()
		end
	end
	--Change Type
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(newRace)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
end