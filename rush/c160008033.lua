--朧撃龍ミラギアスターＦ
--Hazy Strike Dragon Miragiastar F
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160003025,160204026)
	--ATK decrease+double attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--piercing+double attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetCondition(s.dircon)
	e2:SetOperation(s.dirop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
--atk down
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.atkfilter(c)
	return c:IsMonster() and c:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
		local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,3,nil)
			if #g2>0 then
				for tc in g2:Iter() do
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(-1500)
					e1:SetReset(RESETS_STANDARD_PHASE_END)
					tc:RegisterEffect(e1)
				end
				--Attack up to twice
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(3201)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
				e2:SetValue(1)
				e2:SetReset(RESETS_STANDARD_PHASE_END)
				c:RegisterEffect(e2)
			end
		end
end
--piercing
function s.dircon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Direct attack
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3205)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end