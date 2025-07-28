--人形の家
--Doll House
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Special Summon 1 monster from your Deck with the same name as each target, as a Level 6 DARK monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Attach 1 "Grandpa Demetto" you control to "Princess Cologne" you control as material, then end the Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_PRINCESS_COLOGNE,CARD_GRANDPA_DEMETTO}
function s.tgfilter(c,e)
	return c:IsType(TYPE_NORMAL) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeEffectTarget(e)
end
function s.resconfunc(cg)
	--Creates a rescon function to be used with Auxiliary.SelectUnselectGroup
	--that will ensure cards in sg will have at least one card in cg with the same name.
	--It also ensures that each card has one exclusive pair.
	return function (sg,e,tp,mg)
		local code0=sg:GetFirst():GetCode()
		local f1=cg:Filter(Card.IsCode,nil,code0)
		if #f1<1 then return end
		if #sg>1 then
			local code1=sg:GetNext():GetCode()
			return (code0==code1 and #f1>1)
				or (cg-f1):IsExists(Card.IsCode,1,nil,code1)
		end
		return true
	end
end
function s.spfilter(c,e,tp)
	c:AssumeProperty(ASSUME_LEVEL,6)
	c:AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_DARK)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e)
	local rescon=s.resconfunc(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp))
	if chk==0 then return ft>0 and aux.SelectUnselectGroup(tg,e,tp,1,1,rescon,0) end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PRINCESS_COLOGNE),tp,LOCATION_ONFIELD,0,1,nil)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(tg,e,tp,1,2,rescon,0) then
		ft=math.min(2,ft)
	else ft=1 end
	local g=aux.SelectUnselectGroup(tg,e,tp,1,ft,rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#g,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local gc=#g
	if gc==0 then return end
	local rescon=s.resconfunc(g)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<gc
		or (gc>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		or not aux.SelectUnselectGroup(sg,e,tp,gc,gc,rescon,0) then return end
	local ssg=aux.SelectUnselectGroup(sg,e,tp,gc,gc,rescon,1,tp,HINTMSG_SPSUMMON)
	if #g==#ssg then
		for sc in ssg:Iter() do
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				--Change its Attribute and Level
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e1:SetValue(ATTRIBUTE_DARK)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				sc:RegisterEffect(e1,true)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CHANGE_LEVEL)
				e2:SetValue(6)
				sc:RegisterEffect(e2,true)
			end
		end
		Duel.SpecialSummonComplete()
	end
end
function s.attachfilter(c,tp)
	return c:IsCode(CARD_GRANDPA_DEMETTO) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
function s.xyzfilter(c,mc,tp)
	return c:IsCode(CARD_PRINCESS_COLOGNE) and c:IsFaceup() and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local attach_c=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if not attach_c then return end
	Duel.HintSelection(attach_c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local xyz_c=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,attach_c,tp):GetFirst()
	if xyz_c then
		Duel.HintSelection(xyz_c)
		if not attach_c:IsImmuneToEffect(e) and not xyz_c:IsImmuneToEffect(e) then
			Duel.Overlay(xyz_c,attach_c,true)
			Duel.BreakEffect()
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
		end
	end
end