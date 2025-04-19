--紋章獣バシリスク (Anime)
--Heraldic Beast Basilik (Anime)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetBattleTarget() end
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToBattle() and tc:IsRelateToBattle() then
		local g=Group.FromCards(c,tc)
		Duel.Destroy(g,REASON_EFFECT)
	end
end