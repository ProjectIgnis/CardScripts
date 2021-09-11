--Tether of Defeat
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetRange(0x5f)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.filter(c,tp)
	return c:IsMonster() and c:IsPreviousControler(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.filter,1,nil,1-tp) then
		e:GetHandler():RegisterFlagEffect(id,0,0,0)
	end
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and tp==Duel.GetTurnPlayer() and aux.CanActivateSkill(tp) and e:GetHandler():GetFlagEffect(id)>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Graveyard
	local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	if op==0 then
		e:GetHandler():ResetFlagEffect(id)
		local tc=Duel.GetDecktopGroup(tp,1)
		Duel.SendtoGrave(tc,REASON_EFFECT)
	elseif op==1 then
		e:GetHandler():ResetFlagEffect(id)
		local tc=Duel.GetDecktopGroup(1-tp,1)
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
end
	