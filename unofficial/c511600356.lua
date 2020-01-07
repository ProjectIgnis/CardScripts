--メタル・モール－フォーゼ
--Metal Molephosis
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:GetRace()~=RACE_ALL and c:GetAttribute()~=0x7f
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local sharedRace=0
	if #g>1 then
		for tc in aux.Next(g) do
			if g:IsExists(function(c,tc) return c:GetRace()&tc:GetRace()>0 end,#g-1,tc,tc) then
				if tc:GetRace()&sharedRace==0 then sharedRace=sharedRace+(sharedRace~tc:GetRace()) end
			end
		end
	end
	local race=Duel.AnnounceRace(tp,1,~sharedRace)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local sharedAtt=0
	if #g>1 then
		for tc in aux.Next(g) do
			if g:IsExists(function(c,tc) return c:GetAttribute()&tc:GetAttribute()>0 end,#g-1,tc,tc) then
				if tc:GetAttribute()&sharedAtt==0 then sharedAtt=sharedAtt+(sharedAtt~tc:GetAttribute()) end
			end
		end
	end
	local att=Duel.AnnounceAttribute(tp,1,~sharedAtt)
	local param=(race<<8)|att
	Duel.SetTargetParam(param)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local param=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local race=param>>8
	local att=param&0xff
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		tc:RegisterEffect(e2)
	end
end
