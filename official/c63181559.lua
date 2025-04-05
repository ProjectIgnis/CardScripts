--トリックスター・ディフュージョン
--Trickstar Diffusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--This turn, your opponent's monsters can only attack the targeted monster while it is face-up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.GetCurrentPhase()<=PHASE_BATTLE end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.atklimtg)
	e2:SetOperation(s.atklimop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TRICKSTAR}
function s.fextra(e,tp,mg)
	local location=not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) and LOCATION_GRAVE or LOCATION_MZONE
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,location,0,nil)
end
function s.linkfilter(c)
	return c:IsLinkSummonable() and c:IsSetCard(SET_TRICKSTAR)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_TRICKSTAR),
					matfilter=aux.FALSE,
					extrafil=s.fextra,
					extraop=Fusion.BanishMaterial}
	local b1=Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Fusion Summon 1 "Trickstar" Fusion Monster by banishing its materials from your GY
		local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_TRICKSTAR),
						matfilter=aux.FALSE,
						extrafil=s.fextra,
						extraop=Fusion.BanishMaterial}
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		--Link Summon 1 "Trickstar" Link Monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if sc then
			Duel.LinkSummon(tp,sc)
		end
	end
end
function s.atklimtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(SET_TRICKSTAR) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_TRICKSTAR),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_TRICKSTAR),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atklimop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		local fid=tc:GetFieldID()
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
		--Your opponent's monsters cannot target monsters for attacks, except that monster
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCondition(function(e) return tc:HasFlagEffect(id) and tc:GetFieldID()==fid end)
		e1:SetValue(function(e,c) return c:HasFlagEffect(id) and c:GetFieldID()==fid end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,0,tp,0,1,aux.Stringid(id,5))
	end
end