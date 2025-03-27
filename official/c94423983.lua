--同契魔術
--Simul Archfiends
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
local TYPE_RITUAL_FUSION_SYNCHRO_XYZ_LINK=TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(0,id)==0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	--Players cannot Special Summon monsters with the same type as they control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Increase ATK of monsters
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_RITUAL_FUSION_SYNCHRO_XYZ_LINK),tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local types={TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}
	for _,typ in ipairs(types) do
		if g:IsExists(Card.IsType,2,nil,typ) then return end
	end
	for tc in g:Iter() do
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,sump,LOCATION_MZONE,0,nil)
	local mtypes=g:GetBitwiseOr(Card.GetType)&TYPE_RITUAL_FUSION_SYNCHRO_XYZ_LINK
	return c:IsType(mtypes)
end