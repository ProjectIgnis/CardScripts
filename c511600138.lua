--漆黒のズムウォル (Anime)
--Dark Diviner (Anime)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--dark synchro summon
	c:EnableReviveLimit()
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTuner(nil),nil,4)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--deckdes
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31919988,0))
	e3:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	--add setcode
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetValue(0x601)
	c:RegisterEffect(e4)
end
function s.tgcon(e,c)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsFaceup() and tc:GetAttack()>e:GetHandler():GetBaseAttack() and tc:IsControler(1-tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	local ct=math.floor((tc:GetAttack()-c:GetBaseAttack())/100)
	tc:CreateEffectRelation(e) 
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc:GetAttack()>c:GetBaseAttack() then
		local ct=math.floor((tc:GetAttack()-c:GetBaseAttack())/100)  
		if Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup()
			and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(c:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
			tc:RegisterEffect(e1)
		end
	end
end