--電脳堺麟－麟々
--Datascape Qilin - Linlin
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0x248}
s.listed_names={id}
local key=TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP
function s.tgtfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x248) and Duel.IsExistingMatchingCard(s.tgvfilter,tp,LOCATION_DECK,0,1,nil,c:GetType()&key)
end
function s.tgvfilter(c,type1)
	return c:IsAbleToGrave() and c:IsSetCard(0x248) and not c:IsType(type1)
end
function s.tgvfilter2(c,type1,type2)
	return c:IsAbleToGrave() and c:IsSetCard(0x248) and not c:IsType(type1) and not c:IsType(type2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tgtfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgtfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgtfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Register Special Summon Limit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	aux.RegisterClientHint(c,EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,1),nil)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not tc:IsFacedown() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=Duel.SelectMatchingCard(tp,s.tgvfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetType()&key)
		if #tg>0 and Duel.SendtoGrave(tg,nil,REASON_EFFECT)>0 then
			local ogc=Duel.GetOperatedGroup():GetFirst()
			if ogc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
				local tg1=tg:GetFirst()
				if Duel.IsExistingMatchingCard(s.tgvfilter2,tp,LOCATION_DECK,0,1,nil,tc:GetType()&key,tg1:GetType()&key) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
					local tg2=Duel.SelectMatchingCard(tp,s.tgvfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetType()&key,tg1:GetType()&key)
					if #tg2>0 then
						Duel.BreakEffect()
						Duel.SendtoGrave(tg2,nil,REASON_EFFECT)
					end
				end
			end
		end
	end
end
function s.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
