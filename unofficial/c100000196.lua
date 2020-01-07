--アトリビュート・マスタリー
--Attribute Mastery
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,nil,nil,nil,s.tg)
	--race
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local rc=Duel.AnnounceAttribute(tp,1,0xffff)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,rc)
	e:GetHandler():SetHint(CHINT_ATTRIBUTE,rc)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if not e:GetHandler():GetFlagEffect(id)==0 then return end
	local q=e:GetHandler():GetFlagEffectLabel(id)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec:GetBattleTarget()
	if chk==0 then return ec and bc and bc:IsFaceup() and bc:IsAttribute(q) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:GetFlagEffect(id)==0 then return end
	local q=c:GetFlagEffectLabel(id)
	local ec=c:GetEquipTarget()
	local bc=ec:GetBattleTarget()
	if ec and bc and bc:IsRelateToBattle() and bc:IsAttribute(q) then Duel.Destroy(bc,REASON_EFFECT) end
end
