--武装竜の襲雷
--Armed Dragon Blitz
--Scripted by Hatter

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.opfilter(c,code,ft,e,tp)
	return c:IsSetCard(0x111) and c:IsCode(code)
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
function s.filter(c,ft,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x111)
		and Duel.IsExistingMatchingCard(s.opfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetCode(),ft,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,ft,e,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,ft,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,ft,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.opfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc:GetCode(),ft,e,tp)
	if #g>0 then
		local sc=g:GetFirst()
		aux.ToHandOrElse(sc,tp,function(c)
						return sc:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end,
						function(c)
							if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP)~=0 then
								--Cannot attack directly
								local e1=Effect.CreateEffect(c)
								e1:SetDescription(3207)
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
								e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
								e1:SetReset(RESET_EVENT+RESETS_STANDARD)
								sc:RegisterEffect(e1)
								Duel.SpecialSummonComplete()
							end
						end,aux.Stringid(id,1))
		end
	--Cannot special summon monsters this turn, except dragon monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3),nil)
end
function s.splimit(e,c)
	return not c:IsRace(RACE_DRAGON)
end