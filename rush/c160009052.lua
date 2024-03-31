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
function s.filter(c)
	return c:IsFaceup() and c:CanBeDoubleTribute(FLAG_DOUBLE_TRIB)
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
		
		return #g>1 and aux.SelectUnselectGroup(g,e,tp,2,2,s.trrescon,0)
	end
end
function s.damfilter(c)
	return c:IsFaceup() and c:IsLevel(6) and c:IsDefense(500)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.trrescon,1,tp,HINTMSG_FACEUP)
	if #tg>0 then
		local c=e:GetHandler()
		for tc in tg:Iter() do
			-- Treat as 2 tributes
			tc:AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB)
		end
	end
	if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.damfilter),tp,LOCATION_MZONE,0,1,nil) then
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB) and c:IsControler(tp) and c:IsFaceup()
end
function s.eftg(e,c)
	return c:IsLevelAbove(7) and c:IsSummonableCard()
end