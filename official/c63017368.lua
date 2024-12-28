--石板の神殿
--Wedju Temple
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Place 1 monster in the Spell/Trap Zone as a Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	--Place "Millennium" monsters that are destroyed in the S/T zone instead of sending them to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	e3:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) and c:HasFlagEffect(id) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MILLENNIUM}
function s.hplfilter(c,tp)
	return c:IsMonster() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.dplfilter(c,tp)
	return c:IsSetCard(SET_MILLENNIUM) and s.hplfilter(c,tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		and Duel.IsExistingMatchingCard(s.hplfilter,tp,LOCATION_HAND,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.dplfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local hc=Duel.SelectMatchingCard(tp,s.hplfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if hc and s.place(hc,c,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local dc=Duel.SelectMatchingCard(tp,s.dplfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if not dc then return end
		Duel.BreakEffect()
		s.place(dc,c,tp)
	end
end
function s.place(c,rc,tp)
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return false end
	--Treated as a Continuous Spell
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	c:RegisterEffect(e1)
	return true
end
function s.repfilter(c,tp)
	return c:IsSetCard(SET_MILLENNIUM) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.repfilter,nil,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return ft>0 and #g>0 and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		if #g>1 then
			ft=math.min(ft,#g)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			g=g:Select(tp,1,ft,nil)
		end
		for sc in g:Iter() do
			sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD,0,1)
		end
		e:SetLabelObject(g)
		g:KeepAlive()
		return true
	end
	return false
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	for tc in g:Iter() do
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
			--Treated as a Continuous Spell
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
			tc:RegisterEffect(e1)
		end
	end
end