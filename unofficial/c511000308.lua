--D3
local s,id=GetID()
function s.initial_effect(c)
	--atk/lv up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--Dogma/Plasma
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={17132130,83965310,99357565}
function s.filter(c)
	return c:IsCode(17132130) or c:IsCode(83965310)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,0,LOCATION_HAND,LOCATION_HAND,nil)
	local tc=g1:GetFirst()
	while tc do
		if tc:GetFlagEffect(id)==0 then
			local e2=Effect.CreateEffect(tc)
			e2:SetDescription(aux.Stringid(64382841,3))
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_SPSUMMON_PROC)
			e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
			e2:SetRange(LOCATION_HAND)
			if tc:IsCode(17132130) then
				e2:SetValue(1)
				e2:SetCondition(s.dogmacon)
				e2:SetOperation(s.dogmaop)
			else
				e2:SetCondition(s.plasmacon)
				e2:SetOperation(s.plasmaop)
			end
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		tc=g1:GetNext()
	end
end
function s.dogmacon(e,c)
	if c==nil then return true end
	local g=Duel.GetReleaseGroup(c:GetControler())
	local d=g:FilterCount(Card.IsSetCard,nil,0xc008)
	local d3=g:FilterCount(Card.IsHasEffect,nil,id)
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-2 and d>0 and #g>1 and d3>0
end
function s.dogmaop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetReleaseGroup(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg1=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,0xc008)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg2=g:FilterSelect(tp,Card.IsHasEffect,1,1,sg1:GetFirst(),id)
	sg1:Merge(sg2)
	Duel.Release(sg1,REASON_COST)
end
function s.plasmacon(e,c)
	if c==nil then return true end
	local g=Duel.GetReleaseGroup(c:GetControler())
	local d2=g:FilterCount(Card.IsHasEffect,nil,id)
	local d3=g:FilterCount(Card.IsHasEffect,nil,id+1)
	local ft=Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)
	return (ft>-2 and #g>1 and d2>0) or (ft>-1 and d3>0)
end
function s.plasmaop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetReleaseGroup(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg1=g:FilterSelect(tp,Card.IsHasEffect,1,1,nil,id)
	if not sg1:GetFirst():IsHasEffect(id+1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg2=g:Select(tp,1,1,sg1:GetFirst())
		sg1:Merge(sg2)
	end
	Duel.Release(sg1,REASON_COST)
end
function s.costfilter(c)
	return c:IsCode(99357565) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,2,nil)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(#g)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetParam(e:GetLabel())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local i=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(511000307+i)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		if i==1 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
			e2:SetValue(s.condition)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e2)
		elseif i==2 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(id)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
			e2:SetValue(s.condition)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e2)
		end
	end
end
function s.condition(e,c)
	return c:IsSetCard(0xc008)
end
