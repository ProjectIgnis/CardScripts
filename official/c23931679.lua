--海竜神－リバイアサン
--Kairyu-Shin - Leviathan
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Adjust
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.adjustop)
	c:RegisterEffect(e1)
	--Cannot Normal/Flip/Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.umicon)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e4:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e4)
	--Search 1 "Umi", or 1 "Kairyu-Shin"/"Sea Stealth" Spell/Trap
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_UMI}
s.listed_series={0x179,0x17a}
function s.umicon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_UMI),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsEnvironment(CARD_UMI)
end
function s.nonwaterfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_WATER)
end
function s.fidfilter(c,code)
	return c:GetFieldID()~=code
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag0=c:GetFlagEffect(id)>0
	local flag1=c:GetFlagEffect(id+1)>0
	if not s.umicon(e,tp,eg,ep,ev,re,r,rp) then
		if flag0 then c:ResetFlagEffect(id) end
		if flag1 then c:ResetFlagEffect(id+1) end
		return
	end
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g0=Duel.GetMatchingGroup(s.nonwaterfilter,tp,LOCATION_MZONE,0,nil)
	local g1=Duel.GetMatchingGroup(s.nonwaterfilter,tp,0,LOCATION_MZONE,nil)
	local ct0=#g0
	local ct1=#g1
	if ct0==0 and flag0 then
		c:ResetFlagEffect(id)
	elseif ct0>0 then
		if flag0 and ct0>1 then
			local fid=c:GetFlagEffectLabel(id)
			g0:Match(s.fidfilter,nil,fid)
		elseif flag0 and ct0==1 then
			g0:Clear()
		elseif not flag0 then
			local tc=g0:GetFirst()
			if ct0>1 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
				tc=g0:Select(tp,1,1,nil):GetFirst()
				Duel.HintSelection(tc,true)
			end
			g0:RemoveCard(tc)
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1,tc:GetFieldID())
		end
	end
	if ct1==0 and flag1 then
		c:ResetFlagEffect(id+1)
	elseif ct1>0 then
		if flag1 and ct1>1 then
			local fid=c:GetFlagEffectLabel(id+1)
			g1:Match(s.fidfilter,nil,fid)
		elseif flag1 and ct1==1 then
			g1:Clear()
		elseif not flag1 then
			local tc=g1:GetFirst()
			if ct1>1 then
				Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,1))
				tc=g1:Select(1-tp,1,1,nil):GetFirst()
				Duel.HintSelection(tc,true)
			end
			g1:RemoveCard(tc)
			c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1,tc:GetFieldID())
		end
	end
	g0:Merge(g1)
	if #g0>0 then
		Duel.SendtoGrave(g0,REASON_RULE)
		Duel.Readjust()
	end
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsAttribute(ATTRIBUTE_WATER) then return false end
	return Duel.IsExistingMatchingCard(s.nonwaterfilter,targetp or sump,LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsCode(CARD_UMI)
		or ((c:IsSetCard(0x179) or c:IsSetCard(0x17a)) and c:IsSpellTrap()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
