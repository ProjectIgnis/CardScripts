--軍貫処『海せん』
--Gunkan Sushipyard Seaside Supper Spot
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Place 1 "Gunkan" card from your Deck on top of your Deck
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1a:SetCondition(s.decktopcon)
	e1a:SetTarget(s.decktoptg)
	e1a:SetOperation(s.decktopop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Your opponent pays LP exactly equal to that monster's DEF in the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GUNKAN}
s.listed_names={CARD_SUSHIP_SHARI}
function s.decktopconfilter(c,tp)
	return c:IsSetCard(SET_GUNKAN) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
function s.decktopcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.decktopconfilter,1,nil,tp)
end
function s.decktoptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,SET_GUNKAN) end
end
function s.decktopop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,SET_GUNKAN):GetFirst()
	if sc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(sc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end
function s.xyzconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsReasonPlayer(1-tp)
		and c:IsSetCard(SET_GUNKAN) and c:IsPreviousSetCard(SET_GUNKAN) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.xyzconfilter,1,nil,tp)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.xyzconfilter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_SUSHIP_SHARI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(SET_GUNKAN) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local def=0
	for tc in g:Iter() do
		if tc:GetPreviousDefenseOnField()<0 then def=0 end
		def=def+tc:GetPreviousDefenseOnField()
	end
	if not Duel.CheckLPCost(1-tp,def) then return end
	Duel.PayLPCost(1-tp,def)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		Duel.BreakEffect()
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local xyzc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
			if xyzc then
				Duel.BreakEffect()
				xyzc:SetMaterial(sg)
				Duel.Overlay(xyzc,sg)
				if Duel.SpecialSummon(xyzc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
					xyzc:CompleteProcedure()
				end
			end
		end
	end
end