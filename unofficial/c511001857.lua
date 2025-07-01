--ラスト・トリック
--Last Trick
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Spell Card your opponent activated to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--Checks for Spell Card activations
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() then
		re:GetHandler():RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~(RESET_TOGRAVE|RESET_LEAVE)),0,1,rp)
	end
end
function s.confilter(c,opp)
	return c:IsReason(REASON_RULE) and c:HasFlagEffect(id) and c:GetFlagEffectLabel(id)==opp and c:IsLocation(LOCATION_GRAVE)
		and c:IsAbleToHand()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.confilter,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.confilter,nil,1-tp)
	if #g==0 then return end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		g=g:Select(tp,1,1,nil)
	end
	Duel.HintSelection(g)
	Duel.SendtoHand(g,tp,REASON_EFFECT)
end
