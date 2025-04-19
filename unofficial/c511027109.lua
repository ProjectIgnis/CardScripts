--聖地の守護結界
--Sacred Defense Barrier
--Made by Dakota
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	c:RegisterEffect(e4)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsRace,RACE_ROCK),1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg:Filter(aux.FaceupFilter(Card.IsRace,RACE_ROCK),nil))
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1096)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	for tc in tg:Iter() do
		if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 and tc:IsPosition(POS_FACEUP_DEFENSE) then
			tc:AddCounter(0x1096,1)
		end
	end
end
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetCounter(0x1096)>0
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=eg:Filter(s.repfilter,nil,tp)
	for tc in g:Iter() do
		tc:RemoveCounter(tp,0x1096,1,REASON_EFFECT)
	end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
function s.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end