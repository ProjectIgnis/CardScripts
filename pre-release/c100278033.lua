-- 人形の家
-- Doll House
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- Attach material and end battle phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.bpcon)
	e3:SetTarget(s.bptg)
	e3:SetOperation(s.bpop)
	c:RegisterEffect(e3)
end
s.listed_names={75574498,44190146}
function s.tgfilter(c,e)
	return c:IsType(TYPE_NORMAL) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeEffectTarget(e)
end
function s.resconfunc(cg)
	-- Creates a rescon function to be used with Auxiliary.SelectUnselectGroup
	-- that will ensure cards in sg will have at least one card in cg with the same name.
	-- It also ensures that each card has one exclusive pair.
	return function (sg,e,tp,mg)
		local code1=sg:GetFirst():GetCode()
		local f1=cg:Filter(Card.IsCode,nil,code1)
		if #f1<1 then return end
		if #sg>1 then
			local code2=sg:GetNext():GetCode()
			return (code1==code2 and #f1>1)
				or (cg-f1):IsExists(Card.IsCode,1,nil,code2)
		end
		return true
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e)
	local rescon=s.resconfunc(Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_DECK,0,nil,e,0,tp,false,false))
	if chk==0 then return ft>0 and aux.SelectUnselectGroup(tg,e,tp,1,1,rescon,0) end
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,75574498),tp,LOCATION_MZONE,0,1,nil)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(tg,e,tp,1,2,rescon,0) then
		ft=math.min(2,ft)
	else ft=1 end
	local g=aux.SelectUnselectGroup(tg,e,tp,1,ft,rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#g,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local gc=#g
	local rescon=s.resconfunc(g)
	local sg=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_DECK,0,nil,e,0,tp,false,false)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<gc
		or gc~=g:FilterCount(Card.IsRelateToEffect,nil,e)
		or (gc>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		or not aux.SelectUnselectGroup(sg,e,tp,gc,gc,rescon,0)
	then return end
	local ssg=aux.SelectUnselectGroup(sg,e,tp,gc,gc,rescon,1,tp,HINTMSG_SPSUMMON)
	if #g==#ssg then
		for sc in ~ssg do
			-- Special summon as Level 6 DARK monster
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(ATTRIBUTE_DARK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CHANGE_LEVEL)
				e2:SetValue(6)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2,true)
			end
		end
		Duel.SpecialSummonComplete()
	end
end
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetAttacker():GetOwner()
end
function s.bptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,75574498),tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,44190146),tp,LOCATION_MZONE,0,1,nil)
	end
end
function s.colfilter(c,e)
	return c:IsFaceup() and c:IsCode(75574498) and not c:IsImmuneToEffect(e)
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCode,44190146),tp,LOCATION_MZONE,0,nil)
	local tg=Duel.GetMatchingGroup(s.colfilter,tp,LOCATION_MZONE,0,nil,e)
	if #mg>0 and #tg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mc=mg:Select(tp,1,1,false):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tc=tg:Select(tp,1,1,false):GetFirst()
		if mc and tc then
			Duel.Overlay(tc,mc)
			Duel.BreakEffect()
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		end
	end
end