--天装騎兵シーカ
--Armatos Legio Seeker
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	if chk==0 then return a and Duel.GetAttackTarget()~=nil and a:IsLinkMonster()
		and a:IsSetCard(0x578) and a:IsFaceup() and a:IsControler(tp)
		and (e:GetHandler():GetLinkedGroup():IsContains(a) or a:GetLinkedGroup():IsContains(e:GetHandler())) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
