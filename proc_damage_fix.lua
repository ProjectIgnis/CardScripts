-- Utilities for functions to handle damage change that don't stack with each other

function Duel.DoubleBattleDamage(ep)
	if Duel.GetFlagEffect(ep,199004583)==0 then
		--199004583 = 100000000 + id of Action Magic Full turn
		local dam=Duel.GetBattleDamage(ep)
		Duel.ChangeBattleDamage(ep,dam*2)
		Duel.RegisterFlagEffect(ep,199004583,RESET_PHASE+PHASE_DAMAGE_CAL,0,0)
	end
end
function Duel.DoublePiercingDamage(ep)
	if Duel.GetFlagEffect(ep,155410871)==0 then
	--155410871 = 100000000 + id of Blue eyes Chaos Max Dragon
		local dam=Duel.GetBattleDamage(ep)
		Duel.ChangeBattleDamage(ep,dam*2)
		Duel.RegisterFlagEffect(ep,155410871,RESET_PHASE+PHASE_DAMAGE_CAL,0,0)
	end
end
function Duel.HalfBattleDamage(ep)
	if Duel.GetFlagEffect(ep,189448140)==0 then
		--155410871 = 100000000 + id of Magician's Defense
		local dam=Duel.GetBattleDamage(ep)
		Duel.ChangeBattleDamage(ep,dam/2)
		Duel.RegisterFlagEffect(ep,189448140,RESET_PHASE+PHASE_DAMAGE_CAL,0,0)
	end
end
