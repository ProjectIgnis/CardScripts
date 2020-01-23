--銀河眼の残光竜
--Galaxy-Eyes Afterglow Dragon
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--special summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--special summon or attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
s.listed_series={0x107b,0x48}
s.listed_names={CARD_GALAXYEYES_P_DRAGON}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.cfilter3(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,CARD_GALAXYEYES_P_DRAGON) end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	local tg=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,e)
	local sg=Duel.GetMatchingGroup(s.cfilter3,tp,LOCATION_MZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,CARD_GALAXYEYES_P_DRAGON)
	local tc=g:GetFirst()
	local op=0
		if #tg>0 and (tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		elseif #tg>0 then op=0
		else op=1 end
		if op==0 then
			local oc=tg:Select(tp,1,1,nil,e):GetFirst()
			if oc:IsImmuneToEffect(e) then Duel.SendtoGrave(tc,REASON_RULE) end
			if oc and oc:IsFaceup() then
				Duel.Overlay(oc,tc)
			end
		else 
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	if ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE then
		local sc=sg:GetFirst()
		for sc in aux.Next(sg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(sc:GetAttack()*2)
			sc:RegisterEffect(e1)
		end
	end
end
