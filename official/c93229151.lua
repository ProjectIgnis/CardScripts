--黄金の雫の神碑
--Runick Smiting Storm
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateMysteruneQPEffect(c,id,0,s.rmtg,s.rmop,1)
	c:RegisterEffect(e1)
end
s.listed_series={SET_RUNICK}
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local max=math.min(Duel.GetFieldGroupCount(tp,0,LOCATION_DECK),Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD))
	if max<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local ct=Duel.AnnounceNumberRange(tp,1,max)
	if ct<1 then return end
	local rg=Duel.GetDecktopGroup(1-tp,ct)
	if #rg>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end