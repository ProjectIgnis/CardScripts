--覇王龍の魂
--Soul of the Supreme King
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon "Supreme King Z-Arc"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon up 4 for monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ZARC} --Supreme King Z-ARC
s.listed_series={SET_PENDULUM_DRAGON,SET_XYZ_DRAGON,SET_SYNCHRO_DRAGON,SET_FUSION_DRAGON}
local LOCATION_HDEG=LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.filter(c,e,tp)
	return c:IsCode(CARD_ZARC) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local c=e:GetHandler()
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		--Return it to the Extra Deck
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(Duel.GetTurnCount()+1)
		e3:SetLabelObject(tc)
		e3:SetCondition(s.tdcon)
		e3:SetOperation(s.tdop)
		Duel.RegisterEffect(e3,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	Duel.SpecialSummonComplete()
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:HasFlagEffect(id) then
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsSpellEffect()
end
function s.spcfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(CARD_ZARC) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HDEG,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,rmc)
	local loc_extr=c:IsLocation(LOCATION_EXTRA)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsSetCard({SET_PENDULUM_DRAGON,SET_XYZ_DRAGON,SET_SYNCHRO_DRAGON,SET_FUSION_DRAGON})
		and ((not loc_extr and Duel.GetMZoneCount(tp,rmc)>0) or (loc_extr and Duel.GetLocationCountFromEx(tp,tp,rmc,c)>0))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HDEG)
end
function s.resfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function s.rescon(checkfunc)
	return function(sg,e,tp,mg)
		return true,Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)<sg:FilterCount(s.resfilter,nil) or not sg:CheckDifferentProperty(checkfunc)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HDEG,0,nil,e,tp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCountFromEx(tp,tp),4)
	if #g>0 and ft>0 then
		local checkfunc=aux.PropertyTableFilter(Card.GetSetCard,SET_PENDULUM_DRAGON,SET_XYZ_DRAGON,SET_SYNCHRO_DRAGON,SET_FUSION_DRAGON)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(checkfunc),1,tp,HINTMSG_SPSUMMON,s.rescon(checkfunc))
		if #sg==0 then return end
		local exg=sg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		local nexg=sg-exg
		for tc in nexg:Iter() do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		for tc in exg:Iter() do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end