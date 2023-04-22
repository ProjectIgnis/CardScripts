--Cloudy Skies of Grey
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CLOUDIAN}
s.counter_place_list={COUNTER_FOG}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Place Fog Counters from destroyed "Cloudian" monster on another face-up monster
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetRange(0x5f)
	e1:SetOperation(s.ctop)
	Duel.RegisterEffect(e1,tp)
end
function s.ctfilter(c)
	local count=c:GetCounter(COUNTER_FOG)
	return c:IsFaceup() and c:IsMonster() and c:IsCanAddCounter(COUNTER_FOG,count)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	for tc in eg:Iter() do
		if tc and tc:IsMonster() and tc:IsSetCard(SET_CLOUDIAN) and tc:IsReason(REASON_DESTROY) and tc:GetCounter(COUNTER_FOG)>0 then
			count=count+tc:GetCounter(COUNTER_FOG)
			if count>0 then
				Duel.Hint(HINT_CARD,0,id)
	   			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
				local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,tc,COUNTER_FOG,count)
	   			if #g>0 then
	   				local sg=g:Select(tp,1,1,nil):GetFirst()
	   				sg:AddCounter(COUNTER_FOG,count)
	   			end
	   		end
		end
	end
end