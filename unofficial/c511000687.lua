--�l�N���E�J�I�X
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--register
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_TO_GRAVE)
		ge2:SetOperation(s.regop)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.filter1(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:GetFlagEffect(id)~=0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank())
end
function s.filter2(c,e,tp,rk)
	return c:GetRank()==rk and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsC()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRank())
	local tg=g:GetFirst()
	if tg and Duel.SpecialSummonStep(tg,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fa0000)
		tg:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tg:RegisterEffect(e2,true)
		tg:CompleteProcedure()
		end
	Duel.SpecialSummonComplete()
end
function s.regfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and not c:IsReason(REASON_RETURN) and c:IsType(TYPE_XYZ) and c:GetFlagEffect(id)==0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local g=eg:Filter(s.regfilter,nil)
	if #g>0 and ph>=0x08 and ph<=0x20 then
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end
	end
end
