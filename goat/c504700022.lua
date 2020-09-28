--スカル・ナイト
--Skull Knight #2 (GOAT)
--Triggers on tribute set as well
--Triggers for the player that used it
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(0xff)
	e2:SetCode(EVENT_MSET)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
end
s.listed_names={15653824}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if r~=REASON_SUMMON or
		e:GetHandler():GetPreviousControler()~=e:GetHandler():GetReasonPlayer() then return false end
	e:SetLabel(e:GetHandler():GetPreviousControler())
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsFaceup() and rc:IsRace(RACE_FIEND)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if not tc:IsSummonType(SUMMON_TYPE_TRIBUTE) or not tc:GetMaterial():IsContains(c)
		 or e:GetHandler():GetPreviousControler()~=e:GetHandler():GetReasonPlayer()
		or not c:IsReason(REASON_SUMMON) then return false end
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return tc:IsRace(RACE_FIEND)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,e:GetLabel(),LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsCode(15653824) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.GoatConfirm(tp,LOCATION_DECK)
	end
end
