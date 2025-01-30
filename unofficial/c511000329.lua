--ヘル・ガントレット
--Infernal Gauntlet
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Grant the equipped monster an additional attack (on monsters)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and not Duel.IsPhase(PHASE_BATTLE) and Duel.GetCurrentChain()==0 end)
	e1:SetCost(s.exatkcost)
	e1:SetOperation(s.exatkop)
	c:RegisterEffect(e1)
end
function s.exatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqc=e:GetHandler():GetEquipTarget()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,eqc) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,eqc)
	Duel.Release(g,REASON_COST)
end
function s.exatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	if eqc then
		local atk_announce_ct=eqc:GetAttackAnnouncedCount()
		local extra_atk_ct=atk_announce_ct==0 and 1 or atk_announce_ct
		--The equipped monster gains an additional attack in addition to its normal attack, but if it attacks using this effect, it cannot attack your opponent directly
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(extra_atk_ct)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		eqc:RegisterEffect(e1)
	end
end