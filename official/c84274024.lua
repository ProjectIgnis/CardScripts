--ペンデュラム・ディメンション
--Pendulum Dimension
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Special summon - Fusion Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.effcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetLabel(TYPE_FUSION)
	c:RegisterEffect(e2)
	--Add to hand - Synchro Summon
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetTarget(s.thtg1)
	e3:SetOperation(s.thop1)
	e3:SetLabel(TYPE_SYNCHRO)
	c:RegisterEffect(e3)
	--Add to hand or Special Summon - Xyz Summon
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	e4:SetLabel(TYPE_XYZ)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(s.valcheck)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_POLYMERIZATION}
function s.valcheck(e,c)
	if c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) and c:GetMaterial():IsExists(Card.IsType,1,nil,TYPE_PENDULUM) then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END&~(RESET_LEAVE|RESET_TOFIELD),0,1)
	end
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(e:GetLabel()) and c:GetFlagEffect(id)~=0 and c:IsSummonPlayer(tp)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and s.cfilter(eg:GetFirst(),e,tp)
end
function s.spfilter(c,e,tp,lv)
	local lvl=c:GetOriginalLevel()
	return lvl>0 and lvl==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg:GetFirst():GetOriginalLevel())
		and Duel.GetFlagEffect(tp,id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local c=e:GetHandler()
	if eg:GetFirst():IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg:GetFirst():GetOriginalLevel()):GetFirst()
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		Duel.SpecialSummonComplete()
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.thfilter1(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetFlagEffect(tp,id+1)==0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)~=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
end
function s.thfilter2(c,e,tp,ft,rk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsLevelBelow(rk) and c:IsType(TYPE_TUNER)
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,ft,eg:GetFirst():GetRank())
		and Duel.GetFlagEffect(tp,id+2)==0 end
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+2)~=0 or eg:GetFirst():IsFacedown() then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft,eg:GetFirst():GetRank())
	if #g>0 then
		tc=g:GetFirst()
		aux.ToHandOrElse(tc,tp,
						function(c) return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end,
						function(c) Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
						aux.Stringid(id,0)
						)
		end
	Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
end
