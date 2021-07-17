--聖蔓の播種
--Sunvine Sowing
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special summon 1 "Sunseed" monster from Deck, take 1000 damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Substitute destruction for a plant link monster(s)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
	--Lists "Sunseed" and "Sunavalon" archetypes
s.listed_series={0x4157,0x1157}
	--Specifically lists "Sunseed Genius Loci"
s.listed_names={27520594}

	--Check for a "Sunavalon" link monster
function s.linkchk(c)
	return c:IsLinkMonster() and c:IsSetCard(0x1157)
end
	--Check for "Sunseed Genius Loci" or a "Sunseed" monster
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x4157) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (Duel.IsExistingMatchingCard(s.linkchk,tp,LOCATION_MZONE,0,1,nil) or c:IsCode(27520594))
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
	--Special summon 1 "Sunseed" monster from Deck, take 1000 damage
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
			Duel.Damage(tp,1000,REASON_EFFECT)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--Cannot Special Summon from the Extra Deck, except Plants
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
	--Clock Lizard filter
function s.lizfilter(e,c)
	return not c:IsOriginalRace(RACE_PLANT)
end
	--Restricted to plant monsters for extra deck
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_PLANT) and c:IsLocation(LOCATION_EXTRA)
end
	--Substitute destruction for a plant link monster(s)
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsRace(RACE_PLANT) and c:IsLinkMonster()
		and not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
