--Baggy Sleeves
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
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
	return c:IsLevelAbove(7) and c:IsPreviousControler(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.filter,1,nil,tp) then
		e:GetHandler():RegisterFlagEffect(id,0,0,0)
	end
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and tp==Duel.GetTurnPlayer() and Duel.GetDrawCount(tp)>0 and e:GetHandler():GetFlagEffect(id)>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--draw replace
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	Duel.Draw(tp,2,REASON_EFFECT+REASON_DRAW)
	e:SetLabel(0)
end
