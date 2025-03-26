--銀河眼の極光波竜
--Galaxy-Eyes Cipher X Dragon
--Scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,10,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--Make LIGHT monsters you currently control unable to be targeted by your opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.Detach(2,2,nil))
	e1:SetTarget(s.cannottgtg)
	e1:SetOperation(s.cannottgop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Return 1 Rank 9 or lower Dragon Xyz Monster from your GY to the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.texsptg)
	e2:SetOperation(s.texspop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_CIPHER_DRAGON}
function s.ovfilter(c,tp,lc)
	return c:IsSetCard(SET_CIPHER_DRAGON,lc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end
function s.cannottgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup() and not c:HasFlagEffect(id)
end
function s.cannottgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cannottgfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.cannottgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cannottgfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	local ct=Duel.IsTurnPlayer(tp) and 2 or 1
	for tc in g:Iter() do
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,ct)
		--Your opponent cannot target it with card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3061)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESETS_STANDARD_PHASE_END,ct)
		tc:RegisterEffect(e1)
	end
end
function s.texfilter(c)
	return c:IsRankBelow(9) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
function s.texsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.texfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.texspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.texfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if not (Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA)) then return end
	local c=e:GetHandler()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if not (#pg<=0 or (#pg==1 and pg:IsContains(c))) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e)
		and c:IsCanBeXyzMaterial(sc,tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		sc:SetMaterial(c)
		Duel.Overlay(sc,c)
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end