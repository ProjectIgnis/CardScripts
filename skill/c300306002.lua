--Forged Steel
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_RED_EYES}
s.listed_names={CARD_REDEYES_B_DRAGON,96561011}
function s.cfilter(c)
	return c:IsMonster() and c:IsFaceup() and (c:IsSetCard(SET_RED_EYES) or (c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON))) and not c:IsCode(CARD_REDEYES_B_DRAGON)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) 
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--OPD Register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Change Dragon to "Red-Eyes Black Dragon"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(CARD_REDEYES_B_DRAGON)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	--"Red-Eyes Darkness Dragon" Special Summon effect
	local ea=Effect.CreateEffect(c)
	ea:SetDescription(aux.Stringid(id,0))
	ea:SetCategory(CATEGORY_SPECIAL_SUMMON)
	ea:SetType(EFFECT_TYPE_IGNITION)
	ea:SetRange(LOCATION_MZONE)
	ea:SetCountLimit(1)
	ea:SetTarget(s.sptg)
	ea:SetOperation(s.spop)
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	eb:SetRange(0x5f)
	eb:SetTargetRange(LOCATION_MZONE,0)
	eb:SetTarget(function(e,c) return c:IsCode(96561011) and c:IsFaceup() end)
	eb:SetLabelObject(ea)
	Duel.RegisterEffect(eb,tp)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
end