--魔弾の射手 スター
--Magical Musketeer Starfire
local s,id=GetID()
function s.initial_effect(c)
	--"Magical Musket" Spell/Traps can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MAGICAL_MUSKET))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	--Special Summon 1 Level 4 or lower "Magical Musket" monster from the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MAGICAL_MUSKET}
s.listed_names={id}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
	--[[
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE|PHASE_DAMAGE_CAL)~=0 or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or c:GetFlagEffect(1)<=0 then return false end
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if loc&LOCATION_SZONE==0 or rc:IsControler(1-p) then
		if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
			seq=rc:GetSequence()
		else
			seq=rc:GetPreviousSequence()
		end
	end
	return c:IsColumn(seq,p,LOCATION_SZONE)
	]]
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(SET_MAGICAL_MUSKET) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tg then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end