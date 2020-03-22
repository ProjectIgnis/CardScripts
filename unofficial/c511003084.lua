--Draw of Fate
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() and Duel.Draw(1-tp,1,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		local h1=Duel.GetDecktopGroup(tp,1):GetFirst()
		Duel.Draw(tp,1,REASON_EFFECT)
		if h1==0 then return end
		local h2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
		Duel.Draw(1-tp,1,REASON_EFFECT)
		if h2==0 then return end
		Duel.ConfirmCards(tp,h1)
		Duel.ConfirmCards(tp,h2)
		local g=Group.FromCards(h1,h2)
		g:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetOperation(s.regop)
		e1:SetLabel(3)
		e1:SetLabelObject(g)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.regop2)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(e3,tp)
		local e4=e2:Clone()
		e4:SetCode(EVENT_CHAINING)
		Duel.RegisterEffect(e4,tp)
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCountLimit(1)
		e5:SetOperation(s.winop)
		e5:SetReset(RESET_PHASE+PHASE_END)
		e5:SetLabelObject(e1)
		Duel.RegisterEffect(e5,tp)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if #g==0 then return end
	local tc=eg:GetFirst()
	if tc==g:GetFirst() and e:GetLabel()&1>0 then
		e:SetLabel(e:GetLabel()&~1)
	end
	if tc==g:GetNext() and e:GetLabel()&2>0 then
		e:SetLabel(e:GetLabel()&~2)
	end
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	if #g==0 then return end
	local tc=eg:GetFirst()
	if tc==g:GetFirst() and e:GetLabel()&1>0 then
		e:GetLabelObject():SetLabel(e:GetLabel()&~1)
	end
	if tc==g:GetNext() and e:GetLabel()&2 then
		e:GetLabelObject():SetLabel(e:GetLabel()&~2)
	end
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()==3 then
		Duel.Win(PLAYER_NONE,WIN_REASON_DRAW_OF_FATE)
	end
	if e:GetLabelObject():GetLabel()==2 then
		Duel.Win(tp,WIN_REASON_DRAW_OF_FATE)
	end
	if e:GetLabelObject():GetLabel()==1 then
		Duel.Win(1-tp,WIN_REASON_DRAW_OF_FATE)
	end
end
