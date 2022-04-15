-- エクスキューティー・アップ！
-- Executie Up!
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Allow treating monsters as 2 tributes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(aux.DoubleTributeCon)	
	e1:SetTarget(s.trtg)
	e1:SetOperation(s.trop)
	c:RegisterEffect(e1)
end
function s.trrescon(sg)
	return #sg==2 and not sg:GetFirst():IsRace(sg:GetNext():GetRace())
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,nil)
		return #g>1 and aux.SelectUnselectGroup(g,e,tp,2,2,s.trrescon,0)
	end
end
function s.damfilter(c)
	return c:IsFaceup() and c:IsLevel(6) and c:IsDefense(500)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.trrescon,1,tp,HINTMSG_FACEUP)
	if #tg>0 then
		local c=e:GetHandler()
		for tc in aux.Next(tg) do
			-- Treat as 2 tributes
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			local e1=aux.summonproc(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,1),s.otfilter)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(LOCATION_HAND,0)
			e2:SetTarget(s.eftg)
			e2:SetLabelObject(e1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
	if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.damfilter),tp,LOCATION_MZONE,0,1,nil) then
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
function s.otfilter(c,tp)
	return c:GetFlagEffect(id)~=0 and c:IsControler(tp) and c:IsFaceup()
end
function s.eftg(e,c)
	return c:IsLevelAbove(7) and c:IsSummonableCard()
end