--ベクター・スケア・デーモン
--Vector Square Archfiend
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(aux.bdogcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp,g,zone)
	return g:IsContains(c) and (Duel.CheckLocation(c:GetControler(),LOCATION_MZONE,c:GetSequence(),true)
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local zone=c:GetLinkedZone(1-tp)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp,lg,zone) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp,lg,zone)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local zone1=c:GetLinkedZone(tp)
	local zone2=c:GetLinkedZone(1-tp)
	if chk==0 then return c:GetLinkedZone()~=0 and (bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone1,true) 
		or bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone2)) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:GetLinkedZone()~=0 and tc:IsRelateToEffect(e) then
		local zone1=c:GetLinkedZone(tp)
		local zone2=c:GetLinkedZone(1-tp)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone1)
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone2) or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone1)
		else
			if Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP,zone2)~=0
				and c:IsRelateToBattle() then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EXTRA_ATTACK)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
