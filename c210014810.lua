--Stunning Performance
--designed by 
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetTarget(s.target2)
	c:RegisterEffect(e3)
end
s.listed_names={0x9b}
function s.mfilter(c)
	return c:IsSetCard(0x9b) and c:IsFaceup() and c:IsType(TYPE_EXTRA)
		and c:GetSummonLocation(LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.filter(c,tp)
	return c:IsOnField() and c:GetSummonPlayer()~=tp and c:IsCanChangePosition()
end
function s.cfilter(c)
	return c:IsSetCard(0x9b) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_ONFIELD+LOCATION_HAND) or not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741))
end
function s.gfilter(c,ft,e,tp,g)
	local ag,atk=g:GetMaxGroup(Card.GetAttack)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetAttack()<=atk
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp) end
	local g=eg:Filter(s.filter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return rp==1-tp and tc:IsOnField() and tc:IsCanChangePosition() end
	Duel.SetTargetCard(tc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local check=false
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		local og=Duel.GetOperatedGroup()
		local tc=og:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_ATTACK)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			if tc:RegisterEffect(e4) and tc:RegisterEffect(e3)
				and tc:RegisterEffect(e2) and tc:RegisterEffect(e1) then
				check=true
			else
				check=false
			end
			tc=og:GetNext()
		end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local pg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if check and pg and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.gfilter,tp,LOCATION_GRAVE,0,1,nil,ft,e,tp,pg) then
			Duel.Hint(HINT_SELECTMSG,tp,HINT_CARD)
			local sg=Duel.SelectMatchingCard(tp,s.gfilter,tp,LOCATION_GRAVE,0,1,1,nil,ft,e,tp,pg)
			if #sg>0 then
				local th=sg:GetFirst():IsAbleToHand()
				local sp=ft>0 and sg:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false)
				local op=0
				if th and sp then op=Duel.SelectOption(tp,aux.Stringid(20065322,0),aux.Stringid(20065322,1))
				elseif th then op=0
				else op=1 end
				if op==0 then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
				else
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end